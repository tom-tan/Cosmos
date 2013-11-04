module cosmos.window;

import derelict.sdl2.sdl;

import cosmos.exception;
import cosmos.canvas;

import std.string;
import std.conv;

static this()
{
    DerelictSDL2.load();
    enforceSDL(SDL_Init(SDL_INIT_VIDEO) == 0);
}

static ~this()
{
    SDL_Quit();
}

class Window
{
    this(string title, int width, int height)
    {
        window = enforceSDL(SDL_CreateWindow(title.toStringz(), SDL_WINDOWPOS_CENTERED,
                                             SDL_WINDOWPOS_CENTERED, width, height,
                                             SDL_WINDOW_SHOWN));
    }

    ~this()
    {
        SDL_DestroyWindow(window);
    }

    @property auto canvas()
    {
        if (canvas_ is null)
        {
            canvas_ = new Canvas(window);
        }
        return canvas_;
    }
private:
    SDL_Window* window;
    Canvas canvas_;
}
