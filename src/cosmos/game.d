module cosmos.game;

import derelict.sdl2.sdl;

import cosmos.board;
import cosmos.face;
import cosmos.canvas;
import cosmos.window;

import std.algorithm;
import std.typecons;
import std.random;
import std.array;
import std.stdio;

enum Message
{
    DoNothing,
    Pause,
    Resume,
    RotateRight,
    RotateLeft,
    MoveRight,
    MoveLeft,
    FastFall,
    SlowFall,
    Quit,
}

class Game
{
    this()
    {
        rnd = Random(unpredictableSeed);
        board = new Board();
        sb = new ScoreBoard();
        putPiece(nextPiece);
        chainBonus = DefaultBonus;
        gravity = gravityForCurrentLevel;
        nowPlaying = true;
        inChain = false;
    }

    ~this()
    {
        board.destroy();
        sb.destroy();
        foreach(p; fallen)
        {
            foreach(i; 0..p.length)
            {
                p[i].destroy();
            }
            p.destroy();
        }
    }

    void recieve(Message msg)
    {
        if (nowPlaying)
        {
            final switch(msg) with(Message)
            {
            case DoNothing, Resume:
                break;
            case Pause:
                nowPlaying = false;
                break;
            case RotateRight:
                if (!inChain) fallen.front.rotateRight();
                break;
            case RotateLeft:
                if (!inChain) fallen.front.rotateLeft();
                break;
            case MoveRight:
                if (!inChain)
                {
                    auto cur = fallen.front;
                    if (cur.x+cur.width+cur.delta <= board.width &&
                        cur.y+cur.height < board.height((cur.x+cur.delta)/cur.width))
                    {
                        cur.moveRight(cur.delta);
                    }
                }
                break;
            case MoveLeft:
                if (!inChain)
                {
                    auto cur = fallen.front;
                    if (cur.x-cur.delta >= 0 &&
                        cur.y+cur.height < board.height((cur.x-cur.delta)/cur.width))
                    {
                        cur.moveLeft(cur.delta);
                    }
                }
                break;
            case FastFall:
                if (!inChain) gravity = gravityForCurrentLevel+GravityDelta;
                break;
            case SlowFall:
                if (!inChain) gravity = gravityForCurrentLevel;
                break;
            case Quit:
                SDL_Event ev;
                ev.type = SDL_QUIT;
                SDL_PushEvent(&ev);
                break;
            }
        }
        else
        {
            switch(msg) with(Message)
            {
            case Resume:
                nowPlaying = true;
                break;
            case Quit:
                SDL_Event ev;
                ev.type = SDL_QUIT;
                SDL_PushEvent(&ev);
                break;
            default:
                break;
            }
        }
    }

    void update()
    {
        if (nowPlaying)
        {
            Piece[] piecesOnBottom;
            foreach(p; fallen)
            {
                if (p.height+p.y == board.height(p.x/p.width))
                {
                    auto positions = board.put(p);
                    piecesOnBottom ~= p;
                    chainStack ~= positions;
                }
                else
                {
                    p.fallUntil(board.height(p.x/p.width), gravity);
                }
            }
            assert(fallen.isSorted);
            fallen = setDifference(fallen, piecesOnBottom).array();

            if (fallen.empty)
            {
                sb.score++;
                level_ = levelFor(sb.score);
                auto tmp = board.chain(chainStack);
                fallen = tmp[0];
                sb.score += tmp[1]*10*chainBonus;
                inChain = true;
                gravity = gravityForCurrentLevel+GravityDelta;
                chainStack = [];
                // chain finished
                if (fallen.empty)
                {
                    if (board.empty)
                    {
                        sb.score += AllDeleteBonus;
                    }
                    if (!canPutPiece)
                    {
                        writeln("Game over");
                        recieve(Message.Quit);
                    }
                    putPiece(nextPiece);
                    inChain = false;
                    gravity = gravityForCurrentLevel;
                    chainBonus = DefaultBonus;
                }
                else
                {
                    chainBonus *= 2;
                }
            }
        }
    }

    void draw(Canvas c, int x, int y)
    {
        c.draw(board, x, y);
        foreach(p; fallen)
        {
            c.draw(p, x, y);
        }

        c.draw(sb, x+board.width+50, y);
    }

    @property auto level() const pure nothrow
    {
        return level_;
    }
private:
    @property auto gravityForCurrentLevel() const pure nothrow
    {
        return level+DefaultGravity;
    }

    @property auto canPutPiece()
    {
        return InitPos.y+Face.height*PieceLength < board.height(InitPos.x/Face.width);
    }

    auto putPiece(Piece next)
    {
        next.position = [InitPos.x, InitPos.y];
        fallen = [next];
    }

    @property auto nextPiece()
    {
        import std.array;
        immutable Faces = [FaceState.Smile, FaceState.SmileAngry,
                           FaceState.Angry, FaceState.AngrySmile];
        FaceState[PieceLength] faces;
        foreach(ref f; faces)
        {
            f = Faces[uniform(0, Faces.length, rnd)];
        }
        return new Piece(faces);
    }

    auto levelFor(uint s)
    {
        return s/LevelThreshold;
    }
    enum DefaultGravity = 1;
    enum DefaultBonus = 1;
    enum AllDeleteBonus = 1000;
    enum PieceLength = 3;
    enum GravityDelta = 5;
    enum LevelThreshold = 500;
    enum Tuple!(int, "x", int, "y") InitPos = tuple(3*Face.width, 0);
    int level_;
    int gravity;
    Board board;
    ScoreBoard sb;
    uint chainBonus;
    bool nowPlaying;
    bool inChain;
    Piece[] fallen;
    Pos[] chainStack;
    Random rnd;
}
