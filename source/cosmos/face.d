module cosmos.face;

import cosmos.resources;
import cosmos.canvas;

import std.conv;

enum FaceState
{
    Smile, SmileAngry, Angry, AngrySmile,
}

class Face
{
    this(FaceState s)
    {
        this.state_ = s;
        img = getImageFor(state_);
    }

    ~this()
    {
        img.destroy();
    }

    void rotateRight()
    {
        state_++;
        if (state_ > FaceState.max)
        {
            state_ = FaceState.min;
        }
        img.destroy();
        img = getImageFor(state_);
    }

    void rotateLeft()
    {
        state_--;
        if (state_ < FaceState.min)
        {
            state_ = FaceState.max;
        }
        img.destroy();
        img = getImageFor(state_);
    }

    @property auto image() pure nothrow
    {
        return img;
    }

    @property auto state() const pure nothrow
    {
        return state_;
    }

    override string toString() const
    {
        return state.to!string();
    }

    enum height = size;
    enum width = size;
private:

    static auto getImageFor(FaceState s)
    {
        return new Image(faceMap[s], size, size);
    }

    enum size = 32;
    FaceState state_;
    Image img;

    static immutable string[FaceState] faceMap;
    static this()
    {
        with(FaceState)
        {
            faceMap = [
                Smile:SMILE,
                SmileAngry:SMILE_ANGRY,
                Angry:ANGRY,
                AngrySmile:ANGRY_SMILE,
                ];
        }
    }
}

class Piece
{
    this(in FaceState[] ss)
    {
        import std.algorithm;
        import std.array;
        faces = ss.map!(a => new Face(a))().array();
    }

    this(Face[] fs)
    {
        faces = fs;
    }

    ~this()
    {
        foreach(ref f; faces)
        {
            f = null;
        }
    }

    void rotateRight()
    {
        foreach(f; faces)
        {
            f.rotateRight();
        }
    }

    void rotateLeft()
    {
        foreach(f; faces)
        {
            f.rotateLeft();
        }
    }

    @property void position(int[] pos)
    {
        x_ = pos[0];
        y_ = pos[1];
    }

    @property auto width() const pure nothrow
    {
        return Face.width;
    }

    @property auto height() const pure nothrow
    {
        return Face.height*faces.length;
    }

    @property auto x() const pure nothrow
    {
        return x_;
    }

    @property auto y() const pure nothrow
    {
        return y_;
    }

    void moveRight(int delta)
    {
        x_ += delta;
    }

    void moveLeft(int delta)
    {
        x_ -= delta;
    }

    void fallUntil(int limit, int delta)
    {
        if (height+y+delta <= limit)
        {
            y_ += delta;
        }
        else
        {
            y_ = limit-height.to!int();
        }
    }

    @property auto length() const pure nothrow
    {
        return faces.length;
    }

    @property auto opIndex(size_t n) pure
    {
        return faces[n];
    }

    enum delta = Face.width;

    void draw(Canvas c, int xs, int ys)
    {
        foreach(int i, f; faces)
        {
            c.draw(f, xs+x, ys+y+i*Face.height);
        }
    }

    override int opCmp(Object obj)
    {
        auto other = cast(typeof(this))obj;
        if (other)
        {
            if (x == other.x)
            {
                return y-other.y;
            }
            return x-other.x;
        }
        return -1;
    }
private:
    Face[] faces;
    int x_, y_;
}
