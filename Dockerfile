# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Restore Dependencies as a separate layer, so that dotnet restore
# will run only if solution/projects change
COPY SkaffoldDemo.sln .
COPY SkaffoldDemo/SkaffoldDemo.csproj SkaffoldDemo/
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet restore SkaffoldDemo.sln

#######################################
### Base image                      ###
### (shared between prod and debug) ###
#######################################
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS='http://+:8080'
CMD ["dotnet", "SkaffoldDemo.dll"]


#######################################
### Production image                ###
#######################################
FROM build AS publish-release
COPY SkaffoldDemo/ SkaffoldDemo/
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish --no-restore -c Release -o /out/release

FROM base AS release
ENV ASPNETCORE_ENVIRONMENT='Production'
COPY --from=publish-release /out/release .


#######################################
### Debbuging image                 ###
#######################################
FROM build AS publish-debug
COPY SkaffoldDemo/ SkaffoldDemo/
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish --no-restore -c Debug -o /out/debug

FROM base AS debug
# Install basic debugging utilities
RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

COPY --from=publish-debug /out/debug .
ENV ASPNETCORE_ENVIRONMENT='Development' \
    Logging__Console__FormatterName=Simple

