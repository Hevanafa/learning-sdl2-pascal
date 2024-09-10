unit main_unit;

{$mode ObjFPC}
{$H+}
{$m+}  // directive for constructors

interface

uses
  Classes, SysUtils, SDL2;

type
  TGameClass = Class(TObject)
    private
      sdlWindow: PSDL_Window;
      sdlRenderer: PSDL_Renderer;
      sdlSurface: PSDL_Surface;
      sdlTexture: PSDL_Texture;
      sdlRect: TSDL_Rect;

    public
      constructor new();
  end;

implementation

constructor TGameClass.new();
begin
  // writeln('Hello from TGameClass!');
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  sdlWindow := sdl_createwindow('Hello SDL', 100, 100, 320, 240, SDL_WINDOW_SHOWN);

  sdlRenderer := SDL_CreateRenderer(sdlWindow, 1, 0);

  // This code crashes
  // Fix: https://forums.libsdl.org/viewtopic.php?p=49260
  // if SDL_CreateWindowAndRenderer(320, 240, SDL_WINDOW_SHOWN, @sdlWindow, @sdlRenderer) <> 0 then
  //   Halt;

  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 'nearest');

  SDL_RenderPresent(sdlRenderer);
  SDL_Delay(5000);

  // clear memory
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow);

  SDL_Quit;


  writeln('Programme execution ended.');
  readln;
end;

end.

