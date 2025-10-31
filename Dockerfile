# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2022

ENV TZ=UTC

# Download and install MSYS2
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri 'https://repo.msys2.org/distrib/msys2-x86_64-latest.sfx.exe' `
    -OutFile 'msys2.exe'; `
    .\msys2.exe -y -oC:\; `
    Remove-Item .\msys2.exe

# Initialize MSYS2 and update
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'; `
    C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'

# Install MinGW-w64 toolchain and build tools
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake make'
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S git mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-cmake make'
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S ninja'

# Set working directory
WORKDIR C:\build

# Install Git first
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S git'

RUN C:\msys64\usr\bin\bash.exe -lc 'mkdir /c/build/tinker && git clone https://github.com/TinkerTools/tinker.git /c/build/tinker'

# Navigate to source directory
RUN C:\msys64\usr\bin\bash.exe -lc 'cd /c/build/tinker && ls -la'

#adding FTTW
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -S pkg-config mingw-w64-x86_64-fftw'

# generator
RUN C:\msys64\usr\bin\bash.exe -lc 'export PATH=/mingw64/bin:$PATH && cd /c/build/tinker && mkdir build && cd build && cmake ../cmake'

RUN C:\msys64\usr\bin\bash.exe -lc 'cd /c/build/tinker/build && ls -la'

# Build with ninja instead of make
RUN C:\msys64\usr\bin\bash.exe -lc 'export PATH=/mingw64/bin:$PATH && cd /c/build/tinker/build && ninja'


# Add this to debug inside the container
#RUN C:\msys64\usr\bin\bash.exe -lc 'export PATH=/mingw64/bin:$PATH && cd /c/build/tinker/build && ./alchemy.exe > ./alchemy-output.txt 2>&1 || true'
#RUN C:\msys64\usr\bin\bash.exe -lc 'cat /c/build/tinker/build/alchemy-output.txt'

# Copy binaries to volume location
RUN C:\msys64\usr\bin\bash.exe -lc 'mkdir -p /c/output && cd /c/build/tinker/build && cp *.exe /c/output'

# Copy all MinGW runtime DLLs
RUN C:\msys64\usr\bin\bash.exe -lc 'cd /mingw64/bin && cp *.dll /c/output/'

RUN C:\msys64\usr\bin\bash.exe -lc 'cd /c/output && ls -la'
