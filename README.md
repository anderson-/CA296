##How to compile and run masm32 with the CA296 library on GNU/Linux

1. Install Wine
2. Download and install [masm32](http://www.masm32.com/masmdl.htm)
3. Copy the following files from your Windows 7 and Visual Studio 2013:
  - C:\Program Files\Microsoft Visual Studio 12.0\VC\lib\oldnames.lib
  - C:\Program Files\Microsoft Visual Studio 12.0\VC\lib\msvcrt.lib
  - C:\Program Files\Microsoft SDKs\Windows\v7.1A\Lib\uuid.lib
4. Paste on the folder: ~/.wine/drive_c/masm32/lib/
5. To compile and link the ASM file run the commands:
  - wine C:/masm32/bin/ml.exe /c /coff \\home\\$user\\example.asm
  - wine C:/masm32/bin/link.exe /SUBSYSTEM:CONSOLE \\home\\$user\\example.obj
6. And to run the exacutable file:
  - WINEDEBUG=-all wineconsole example.exe
