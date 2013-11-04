module cosmos.board;

import derelict.sdl2.sdl;

import cosmos.resources;
import cosmos.canvas;
import cosmos.exception;
import cosmos.face;

import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.range;

alias Pos = Tuple!(int, "x", int, "y");

enum Direction
{
    Up, UpRight, Right, DownRight,
    Down, DownLeft, Left, UpLeft, Dummy,
}

auto otherSize(Direction d)
{
    final switch(d) with(Direction)
    {
    case Up:
        return Down;
    case UpRight:
        return DownLeft;
    case Right:
        return Left;
    case DownRight:
        return UpLeft;
    case Down:
        return Up;
    case DownLeft:
        return UpRight;
    case Left:
        return Right;
    case UpLeft:
        return DownRight;
    case Dummy:
        assert(false);
    }
}

class Board
{
    this()
    {
        img = new Image(BOARD, width, height);
    }

    ~this()
    {
        img.destroy();
        foreach(fs; faces)
        {
            foreach(f; fs)
            {
                if (f !is null)
                {
                    f.destroy();
                }
            }
        }
    }

    auto chain(Pos[] fs)
    {
        Piece[] toBeFallen;
        auto vanished = vanish(fs).array();
        foreach(v; vanished.sort!((a, b) {
                    if (a.x == b.x) return a.y > b.y;
                    else            return a.x < b.x;
                })().uniq!"a.x == b.x"()) // uniq の使い方が実装依存かもしれない
        {
            foreach(fallen; zip(iota(v.y), faces[v.x][0..v.y]).splitter!"a[1] is null"().filter!"!a.empty"().array().retro())
            {
                auto piece = new Piece(fallen.map!"a[1]"().array());
                piece.position = indexToPosition(Pos(v.x, fallen.front[0]));
                toBeFallen ~= piece;
                foreach(i; fallen.front[0]..fallen.front[0]+piece.length)
                {
                    faces[v.x][i] = null;
                }
            }
        }
        return tuple(toBeFallen, vanished.length);
    }

    auto put(Piece[] ps)
    {
        Pos[] fs;
        foreach(p; ps)
        {
            auto idx = posToIndex(p);
            foreach(i; 0..p.length)
            {
                faces[idx.x][idx.y+i] = p[i];
            }
            fs ~= sequence!((a, n) => Pos(a[0].x, (a[0].y+n).to!int()))(idx).take(p.length).array();
        }
        return fs;
    }

    auto put(Piece p)
    {
        return put([p]);
    }

    auto vanish(Range)(Range ps)
    {
        bool[Pos] toBeVanished;
        foreach(p; ps)
        {
            vanish(p, toBeVanished);
        }
        foreach(v; toBeVanished.keys)
        {
            faces[v.x][v.y].destroy();
            faces[v.x][v.y] = null;
        }
        return toBeVanished.byKey;
    }

    enum width = xsize*Face.width;

    @property auto height()
    {
        return height_;
    }

    @property auto height(int x)
    {
        auto pos = faces[x][].countUntil!"a !is null"().to!int();
        if (pos == -1)
        {
            return height;
        }
        else
        {
            return pos*Face.height;
        }
    }

    void draw(Canvas c, int x, int y)
    {
        c.draw(img, x, y);

        foreach(x_, fs; faces)
        {
            foreach(y_, f; fs)
            {
                if (f !is null)
                {
                    c.draw(f, x+Face.width*x_.to!int(),
                           y+Face.height*y_.to!int());
                }
            }
        }
    }

    auto empty()
    {
        return faces[].all!(fs => fs[].all!"a is null"())();
    }
private:
    auto posToIndex(Piece ch)
    {
        int x = ch.x/Face.width;
        int y = ch.y/Face.height;
        return Pos(x, y);
    }

    auto indexToPosition(Pos p)
    {
        return [p.x*Face.width, p.y*Face.height];
    }

    auto getSeqStart(Pos cur, Direction dir)
    {
        if (auto p1 = nextPos(cur, dir))
        {
            if (auto p2 = nextPos(*p1, dir))
            {
                return [cur, *p1, *p2];
            }
        }
        return null;
    }

    auto getSeqMiddle(Pos cur, Direction dir)
    {
        if (auto p1 = nextPos(cur, dir))
        {
            if (auto p2 = nextPos(cur, otherSize(dir)))
            {
                return [cur, *p1, *p2];
            }
        }
        return null;
    }

    auto nextPos(Pos cur, Direction dir)
    {
        Pos* pos;
        final switch(dir) with(Direction)
        {
        case Up:
            pos = new Pos(cur.x, cur.y-1);
            break;
        case UpRight:
            pos = new Pos(cur.x+1, cur.y-1);
            break;
        case Right:
            pos = new Pos(cur.x+1, cur.y);
            break;
        case DownRight:
            pos = new Pos(cur.x+1, cur.y+1);
            break;
        case Down:
            pos = new Pos(cur.x, cur.y+1);
            break;
        case DownLeft:
            pos = new Pos(cur.x-1, cur.y+1);
            break;
        case Left:
            pos = new Pos(cur.x-1, cur.y);
            break;
        case UpLeft:
            pos = new Pos(cur.x-1, cur.y-1);
            break;
        case Dummy:
            assert(false);
        }
        if (0 <= pos.x && pos.x < xsize &&
            0 <= pos.y && pos.y < ysize)
        {
            return pos;
        }
        else
        {
            return null;
        }
    }

    void vanish(Pos p, ref bool[Pos] toBeVanished)
    {
        foreach(d; Direction.min..Direction.max)
        {
            auto seq0 = getSeqStart(p, d);
            if (seq0.all!(pos => faces[pos.x][pos.y] !is null)() &&
                seq0.map!(pos => faces[pos.x][pos.y].state)().uniq().walkLength() == 1)
            {
                foreach(v; seq0)
                {
                    if (v !in toBeVanished)
                    {
                        toBeVanished[v] = true;
                    }
                }
            }
            auto seq1 = getSeqMiddle(p, d);
            if (seq1.all!(pos => faces[pos.x][pos.y] !is null)() &&
                seq1.map!(pos => faces[pos.x][pos.y].state)().uniq().walkLength() == 1)
            {
                foreach(v; seq1)
                {
                    if (v !in toBeVanished)
                    {
                        toBeVanished[v] = true;
                    }
                }
            }
        }
    }

    Image img;
    Face[ysize][xsize] faces;
    enum xsize = 7;
    enum ysize = 15;
    enum height_ = Face.size*ysize;
}

class ScoreBoard
{
    this()
    {
        img = new Image(BOARD, width, height);
        foreach(dchar i; '0'..'9'+1)
        {
            nums[i] = new Image(numMap[i], 16, 32);
        }
    }

    ~this()
    {
        img.destroy();
        foreach(n; nums)
        {
            n.destroy();
        }
    }

    void draw(Canvas c, int x, int y)
    {
        c.draw(img, x, y);
        int i;
        foreach(ch; score.to!string().retro())
        {
            c.draw(nums[ch], x+width-20-16*i, y+10);
            i++;
        }
    }

    uint score;

    enum width = 100;
    enum height = 50;
private:
    Image img;
    Image[dchar] nums;

    static immutable string[dchar] numMap;
    static this()
    {
        numMap = [
            '1':ONE,
            '2':TWO,
            '3':THREE,
            '4':FOUR,
            '5':FIVE,
            '6':SIX,
            '7':SEVEN,
            '8':EIGHT,
            '9':NINE,
            '0':ZERO,
            ];
    }
}
