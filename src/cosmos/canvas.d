module cosmos.canvas;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import cosmos.exception;

import std.exception;
import std.string;
import std.typecons;

static this()
{
    enum ImageFlag = IMG_INIT_PNG;
    DerelictSDL2Image.load();
    enforce((IMG_Init(ImageFlag)&ImageFlag) == ImageFlag);
}

static ~this()
{
    IMG_Quit();
}

class Canvas
{
    this(SDL_Window* w)
    {
        ren = enforceSDL(SDL_CreateRenderer(w, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC));
    }

    ~this()
    {
        SDL_DestroyRenderer(ren);
    }

    void clear()
    {
        SDL_RenderClear(ren);
    }

    void draw(T)(T p, int x_, int y_)
        if (!is(T : Image) && is(typeof(p.image) : Image))
    {
        draw(p.image, x_, y_);
    }

    void draw(Image p, int x_, int y_)
    {
        SDL_Rect rect;
        with(rect)
        {
            x = x_;
            y = y_;
            w = p.width;
            h = p.height;
        }
        auto texture = enforceSDL(SDL_CreateTextureFromSurface(ren, p.img));
        scope(exit) SDL_DestroyTexture(texture);
        SDL_RenderCopy(ren, texture, null, &rect);
    }

    void draw(T)(T p, int x_, int y_)
        if (__traits(compiles, p.draw(this, x_, y_)))
    {
        p.draw(this, x_, y_);
    }

    void show()
    {
        SDL_RenderPresent(ren);
    }
private:
    SDL_Renderer* ren;
}

class Image
{
    this(string name, int width, int height)
    {
        this.width_ = width;
        this.height_ = height;
        img = enforceIMG(IMG_Load(name.toStringz()));
    }

    this(SDL_Surface* img)
    {
        this.img = img;
    }

    ~this()
    {
        SDL_FreeSurface(img);
    }

    @property auto width() const pure nothrow
    {
        return width_;
    }

    @property auto height() const pure nothrow
    {
        return height_;
    }

private:
    SDL_Surface* img;
    int width_, height_;
}
