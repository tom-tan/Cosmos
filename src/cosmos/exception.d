module cosmos.exception;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.exception;
import std.conv;

class SDLException : Exception
{
    this(string msg, string file = null, size_t line = 0)
    {
        auto s = SDL_GetError();
        super(msg~"("~s.to!string()~")", file, line);
    }
}

class IMGException : Exception
{
    this(string msg, string file = null, size_t line = 0)
    {
        auto s = IMG_GetError();
        super(msg~"("~s.to!string()~")", file, line);
    }
}

alias enforceSDL = enforceEx!SDLException;
alias enforceIMG = enforceEx!IMGException;
