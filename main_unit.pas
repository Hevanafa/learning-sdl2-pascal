unit main_unit;

{$mode ObjFPC}
{$H+}
{$m+}  // directive for constructors
// https://forum.lazarus.freepascal.org/index.php?topic=38639.0
{$COPERATORS ON}  // enables C operators like += and -=

interface

uses
  Classes, SysUtils, DateUtils,
  SDL2, SDL2_ttf;

type
  TGameClass = Class(TObject)
    private
      done: boolean;
      sdlKeyboardState: PUInt8;
      sdlWindow: PSDL_Window;
      sdlRenderer: PSDL_Renderer;
      sdlSurface: PSDL_Surface;
      sdlTexture: PSDL_Texture;
      sdlRect: TSDL_Rect;

      font: PTTF_Font;
      textRect: TSDL_Rect;
      fg, bg: TSDL_Color;

      last_t: TDateTime;
      dt: real;  // single or float

    public
      constructor new();
      procedure update();
      procedure draw();
  end;

implementation

constructor TGameClass.new();
begin
  // writeln('Hello from TGameClass!');
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  sdlWindow := sdl_createwindow('Hello SDL', 100, 100, 320, 240, SDL_WINDOW_SHOWN);
  if sdlWindow = nil then Halt;

  sdlRenderer := SDL_CreateRenderer(sdlWindow, 1, 0);
  if sdlRenderer = nil then Halt;

  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 'nearest');

  // This code crashes
  // Fix: https://forums.libsdl.org/viewtopic.php?p=49260
  // if SDL_CreateWindowAndRenderer(320, 240, SDL_WINDOW_SHOWN, @sdlWindow, @sdlRenderer) <> 0 then
  //   Halt;

  // Init font
  if TTF_Init < 0 then Halt;
  font := TTF_OpenFont('C:\windows\fonts\arial.ttf', 20);

  fg.r := 255; fg.g := 255; fg.b := 255;


  sdlKeyboardState := SDL_GetKeyboardState(nil);

  last_t := now;

  // init rectangle
  sdlRect.x := 50;
  sdlRect.y := 50;
  sdlRect.w := 10;
  sdlRect.h := 10;

  while not done do
  begin
    // writeln(dt);  // debug delta_t

    update;
    draw;

    dt := DateUtils.MilliSecondsBetween(Now, last_t) / 1000;
    last_t := Now;

    sdl_delay(16);
  end;

  // clear memory
  ttf_closefont(font);
  ttf_quit;

  sdl_freesurface(sdlsurface);
  sdl_destroytexture(sdltexture);

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow);

  SDL_Quit;


  writeln('Programme execution ended.');
  readln;
end;


procedure TGameClass.update();
begin
  SDL_PumpEvents;

  if sdlKeyboardState[SDL_SCANCODE_ESCAPE] = 1 then
    done := true;

  if sdlKeyboardState[SDL_SCANCODE_W] = 1 then
    sdlRect.y -= 1;
  if sdlKeyboardState[SDL_SCANCODE_S] = 1 then
    sdlRect.y += 1;

  if sdlKeyboardState[SDL_SCANCODE_A] = 1 then
    sdlRect.x -= 1;
  if sdlKeyboardState[SDL_SCANCODE_D] = 1 then
    sdlRect.x += 1;
end;


procedure TGameClass.draw();
begin
  // clear screen
  SDL_SetRenderDrawColor(sdlRenderer, 100, 149, 237, SDL_ALPHA_OPAQUE);
  SDL_RenderClear(sdlRenderer);

  // draw the little black square
  SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
  SDL_RenderDrawRect(sdlRenderer, @sdlRect);

  sdlSurface := TTF_RenderText(font, 'Hello from TGameClass!', fg, bg);
  sdlTexture := SDL_CreateTextureFromSurface(sdlRenderer, sdlSurface);

  textRect.w := sdlSurface^.w;
  textRect.h := sdlSurface^.h;

  sdl_rendercopy(sdlrenderer, sdltexture, nil, @textRect);

  SDL_RenderPresent(sdlRenderer);
end;

end.

