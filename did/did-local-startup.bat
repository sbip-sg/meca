@echo off
REM Prerequisites: Docker ganache container, Node, Java, Maven, jq
echo STARTING DID SERVICE...

set publicKey=4261665221056439992349256207169667065315027578390647705456165282391832261498313490844998910722927847484140730450920258944230161311480552650871661291293643
set /p publicKey=Enter your (issuer) public key: (%publicKey%)
set privateKey=1328425420547362631071238982342267720425764562371687816399115197280144756941
set /p privateKey=Enter your (issuer) private key: (%privateKey%)

REM Compile jar file
set confirmCompile=Y
set /p confirmCompile=Do you need to compile the jar file? (Y/N): (%confirmCompile%)
if /i "%confirmCompile%"=="Y" (
    echo ===========================================================================================
    echo Compiling jar file...
    echo ===========================================================================================
    call mvn install -DskipTests
)

REM Start Spring Boot application in a separate console
REM Does not check for updates
@REM mvn install -o 
start java -Dspring.profiles.active=verifier -jar target/did-0.0.1-SNAPSHOT.jar
start java -Dspring.profiles.active=issuer -jar target/did-0.0.1-SNAPSHOT.jar

REM Wait for application to start up
echo ===========================================================================================
echo Waiting for Spring Boot application to start up...
echo ===========================================================================================
timeout /t 10

REM Call POST request on the service and save private key
set did=
for /f "tokens=*" %%a in ('curl -X POST -H "Content-Type: application/json" -d "{\"publicKey\":\"%publicKey%\"}" http://localhost:8080/api/v1/did/create ^| jq -r ".result.did"') do set did=%%a

if "%did%"=="" (
  echo Error: No response received.
) else (
  echo DID received: %did%
  mkdir keys
  for /f "tokens=3 delims=:" %%a in ("%did%") do set fileName=%%a
  echo %privateKey% > keys/%fileName%
  echo Private key saved to keys/%fileName%
)