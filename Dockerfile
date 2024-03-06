FROM ubuntu:focal

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
# Install the base set of packages
RUN apt-get update; apt-get -y upgrade;\
    apt-get install -y python3 python3-pip;\
    rm -rf /tmp/*
RUN apt-get -y install apt-utils git
RUN apt-get -y install curl
RUN apt-get -y install wget
RUN apt-get -y install maven && apt-get clean

RUN mkdir /git
# Install git packages
# Add idnits
RUN cd /git && git clone https://github.com/ietf-tools/idnits.git
ENV PATH="${PATH}:/git/idnits"
ENV PATH $PATH:/git/idnits

# Add rfcstrip
RUN cd /git && git clone https://github.com/mbj4668/rfcstrip.git
RUN cd /git/rfcstrip
ENV PATH $PATH:/git/rfcstrip

# Install languagetool
RUN cd /git && git clone --depth 5 https://github.com/languagetool-org/languagetool.git
RUN cd /git/languagetool && ./install.sh
ENV PATH $PATH:/git/languagetool

# Copy the idreview script over
COPY src/idreview/idreview /usr/local/bin
ENV PATH $PATH:/usr/local/bin

# Install aspell and English dictionary.
RUN mkdir /git/aspell
COPY src/aspell/aspell-0.60.8.1.tar /git/aspell
RUN cd /git/aspell && tar xvf aspell-0.60.8.1.tar
RUN cd /git/aspell/aspell-0.60.8.1 && ./configure && make && make install
COPY src/aspell/dictionary/aspell6-en-2020.12.07-0.tar.bz2 /git/aspell
RUN mkdir /usr/local/lib/aspell
COPY src/aspell/dictionary/aspell6-en-2020.12.07-0.tar.bz2 /usr/local/lib/aspell
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
RUN cd /git/aspell && tar xvf aspell6-en-2020.12.07-0.tar.bz2 && cd aspell6-en-2020.12.07-0 && ./configure && make && make install

# Install codespell
RUN pip install codespell