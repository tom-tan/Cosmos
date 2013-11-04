module simplesdl2;

import derelict.sdl2.sdl;

import cosmos.exception;
import cosmos.window;
import cosmos.canvas;
import cosmos.face;
import cosmos.board;
import cosmos.resources;
import cosmos.game;

import std.stdio;

@property auto toMessage(in SDL_Event ev)
in {
    assert(ev.type == SDL_KEYDOWN ||
           ev.type == SDL_KEYUP);
} body {
    if (ev.type == SDL_KEYDOWN)
    {
        switch(ev.key.keysym.sym) with(Message)
        {
        case SDLK_RIGHT:
            return MoveRight;
        case SDLK_LEFT:
            return MoveLeft;
        case SDLK_DOWN:
            return FastFall;
        case SDLK_SPACE:
            return RotateRight;
        case SDLK_p:
            return Pause;
        case SDLK_r:
            return Resume;
        case SDLK_q:
            return Quit;
        default:
            return DoNothing;
        }
    }
    else
    {
        switch(ev.key.keysym.sym) with(Message)
        {
        case SDLK_DOWN:
            return SlowFall;
        default:
            return DoNothing;
        }
    }
}

void main()
{
    auto window = new Window("Cosmos", 800, 600);
    scope(exit) window.destroy();

    auto canvas = window.canvas;
    scope(exit) canvas.destroy();

    auto background = new Image(BACKGROUND, 800, 600);
    scope(exit) background.destroy();

    auto game = new Game();
    scope(exit) game.destroy();

    {
        canvas.clear();
        scope(exit) canvas.show();
        canvas.draw(background, 0, 0);
        canvas.draw(game, 250, 50);
    }

MainLoop:
    while (true)
    {
        SDL_Event e = void;

        canvas.clear();
        scope(exit) canvas.show();
        canvas.draw(background, 0, 0);
        scope(exit)
        {
            game.update();
            canvas.draw(game, 250, 50);
        }

        while (SDL_PollEvent(&e))
        {
            switch (e.type)
            {
            case SDL_QUIT:
                break MainLoop;
            case SDL_KEYDOWN, SDL_KEYUP:
                game.recieve(e.toMessage);
                break;
            default:
                break;
            }
        }
    }
}
