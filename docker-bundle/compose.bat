@echo off

if [%1]==[] goto usage

@echo Make sure to have the web app available under the webapps/ directory.
pause
docker build -t orca:%1 -t 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:%1 .
docker push 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:%1
@echo Done.
goto :eof

:usage
@echo Usage: %0 ^<version^>
exit /B 1
