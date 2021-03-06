FROM buildpack-deps:jessie-scm

#wrk 
RUN apt-get update \
    && apt-get install -y build-essential libssl-dev git \
    && git clone https://github.com/wg/wrk.git \
    && cd wrk \
    && make \
    && cp wrk /usr/local/bin


# Install .NET CLI dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 1.0.0-preview2-003156
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/$DOTNET_SDK_VERSION/dotnet-dev-debian-x64.$DOTNET_SDK_VERSION.tar.gz

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 1.0.0-preview2-1-003177
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/$DOTNET_SDK_VERSION/dotnet-dev-debian-x64.$DOTNET_SDK_VERSION.tar.gz

RUN curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && tar --overwrite-dir -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz 
    
# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch

#mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF  \
    && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.6.2.7 main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list && apt-get update \
    && apt-get install -y mono-devel ca-certificates-mono fsharp mono-vbnc nuget referenceassemblies-pcl mono-complete \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y lsof 
COPY . /usr/src/app/source
WORKDIR /usr/src/app/source
EXPOSE 8083

CMD "./build.sh"