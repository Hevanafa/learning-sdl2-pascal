unit main_unit;

{$mode ObjFPC}
{$H+}
{$m+}  // directive for constructors
// https://forum.lazarus.freepascal.org/index.php?topic=38639.0
{$COPERATORS ON}  // enables C operators like += and -=

interface

uses
  Classes, SysUtils, DateUtils,
  SDL2, SDL2_ttf, SDL2_image;

type
  TGameClass = Class(TObject)
    private
      done: boolean;

      sdlEvent: PSDL_Event;

      sdlKeyboardState: PUInt8;
      sdlWindow: PSDL_Window;
      sdlRenderer: PSDL_Renderer;
      sdlRect: TSDL_Rect;

      font: PTTF_Font;
      textRect: TSDL_Rect;
      textSurface: PSDL_Surface;
      textTexture: PSDL_Texture;
      fg, bg: TSDL_Color;

      last_t: TDateTime;
      dt: real;  // single or float

      last_fps: integer;
      fps: integer;
      fps_t: real;

      nothingThereTexture: PSDL_Texture;
      nothingThereRect: tsdl_rect;

      story: array of string;
      angle: double;

      const SCREEN_WIDTH = 800;
      const SCREEN_HEIGHT = 480;


    public
      constructor create();
      procedure set_fg(r: uint8; g: uint8; b: uint8; a: uint8 = SDL_ALPHA_OPAQUE);
      procedure draw_str(text: string; x: integer = 0; y: integer = 0);
      procedure init_sdl();

      procedure load_story();

      procedure update();
      procedure draw();
  end;

implementation

constructor TGameClass.create();
begin
  load_story;

  init_sdl;

  nothingThereTexture := IMG_LoadTexture(sdlRenderer, 'images\NothingThere.png');
  if nothingThereTexture = nil then halt;

  while not done do
  begin
    // writeln(dt);  // debug delta_t

    update;
    draw;

    dt := DateUtils.MilliSecondsBetween(Now, last_t) / 1000;
    last_t := Now;

    // update FPS
    fps_t += dt;
    fps += 1;
    if fps_t >= 1.0 then begin
      fps_t -= 1.0;
      last_fps := fps;
      fps := 1;
    end;

    sdl_delay(15);
  end;

  // clear memory
  TTF_CloseFont(font);
  TTF_Quit;

  SDL_DestroyTexture(nothingThereTexture);

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow);

  SDL_Quit;


  // writeln('Programme execution ended.');
  // readln;
end;


procedure TGameClass.load_story();
begin
  setlength(story, 3);
  story[0] := 'Hello';
  story[1] := 'Second line';
  story[2] := 'Third line';
end;


procedure TGameClass.init_sdl();
begin
  // writeln('Hello from TGameClass!');
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  sdlWindow := sdl_createwindow(
            'Hello SDL',
            100, 100, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);

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
  font := TTF_OpenFont('fonts\PixelOperator8.ttf', 12);

  fg.r := 255; fg.g := 255; fg.b := 255;
  bg.a := 0;


  sdlKeyboardState := SDL_GetKeyboardState(nil);

  last_t := now;

  // init rectangle
  sdlRect.x := 50;
  sdlRect.y := 50;
  sdlRect.w := 10;
  sdlRect.h := 10;

  new(sdlEvent);
end;

procedure TGameClass.update();
begin
  // SDL_PumpEvents;

  // https://stackoverflow.com/questions/56435371/
  while SDL_PollEvent(sdlEvent) = 1 do begin
    case sdlevent^.type_ of
      SDL_KEYDOWN: begin
        case sdlevent^.key.keysym.sym of
          SDLK_ESCAPE: done := true;

          SDLK_UP, SDLK_W: sdlRect.y -= 4;
          SDLK_DOWN, SDLK_S: sdlRect.y += 4;

          SDLK_LEFT, SDLK_A: sdlRect.x -= 4;
          SDLK_RIGHT, SDLK_D: sdlRect.x += 4;
        end;
      end;

      SDL_WINDOWEVENT: begin
        case sdlevent^.window.event of
          // https://stackoverflow.com/questions/49686915/
          SDL_WINDOWEVENT_CLOSE: done := true;
        end;
      end;
    end;
  end;

  angle += 0.1;

  {
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
  }
end;


procedure TGameClass.set_fg(r: uint8; g: uint8; b: uint8; a: uint8 = SDL_ALPHA_OPAQUE);
begin
  fg.r := r;
  fg.g := g;
  fg.b := b;
  fg.a := a;
end;

procedure TGameClass.draw_str(text: string; x: integer = 0; y: integer = 0);
begin
  // render text
  // probably this causes memory leak when not freed
  textSurface := TTF_RenderText_Blended(font, pchar(text), fg);
  textTexture := SDL_CreateTextureFromSurface(sdlRenderer, textSurface);

  // get the correct surface size
  // https://stackoverflow.com/questions/22886500/
  textRect.x := x;
  textRect.y := y;
  textRect.w := textSurface^.w;
  textRect.h := textSurface^.h;

  sdl_rendercopy(sdlRenderer, textTexture, nil, @textRect);

  SDL_FreeSurface(textSurface);
  SDL_DestroyTexture(texttexture);
end;


procedure TGameClass.draw();
var
  a: integer;
  i: integer; // for the random number example
begin
  // clear screen
  SDL_SetRenderDrawColor(sdlRenderer, 100, 149, 237, SDL_ALPHA_OPAQUE);
  SDL_RenderClear(sdlRenderer);

  if nothingThereRect.w = 0 then
    SDL_QueryTexture(nothingThereTexture, nil, nil,
                     @nothingThereRect.w, @nothingThereRect.h);

  nothingThereRect.x := trunc((SCREEN_WIDTH - nothingThereRect.w) / 2);
  nothingThereRect.y := trunc((SCREEN_HEIGHT - nothingThereRect.h) / 2);

  // SDL_RenderCopy(sdlRenderer, nothingThereTexture, nil, @nothingThereRect);
  SDL_RenderCopyEx(sdlRenderer, nothingThereTexture, nil, @nothingThereRect, angle, nil, SDL_FLIP_NONE);

  // draw the little black square
  // sdlRect.w := 10;
  // sdlRect.h := 10;
  SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
  SDL_RenderDrawRect(sdlRenderer, @sdlRect);

  // High() is the same as UBound in VB6, the opposite of Low()
  // https://stackoverflow.com/questions/30334814/
  for a := 0 to High(story) do
    draw_str(story[a], 0, 20 * a);

  // string concatenation
  draw_str(format('FPS: %d', [last_fps]), SCREEN_WIDTH - 100, 0);

  // 2nd string concatenation example
  i := random(100);
  draw_str('i = ' + IntToStr(i), 0, 80);

  set_fg(255, 255, 0);
  draw_str('WASD - Move', 0, SCREEN_HEIGHT - 40);
  draw_str('Esc - Quit', 0, SCREEN_HEIGHT - 20);

  SDL_RenderPresent(sdlRenderer);
end;

end.

