To get the EXE files you need to run these commads:

```docker build -t tinker:latest .```

```docker run --name tinker tinker:latest```

```docker cp tinker-build:C:\output\ C:\tinker-output\```

And you can find the exe files on your local machine `C:\tinker-output\output` folder
