# Start using tex distribution
FROM texlive/texlive:latest

# Install additional dependencies
RUN apt-get update;

# install python and openpyxl
RUN apt-get install -y python3 python3-openpyxl;

# install paratype font
RUN apt-get install -y fonts-paratype;
RUN fc-cache -fv;

# install inotify-tools for monitoring / mimicing latexmk -pvc
RUN apt-get install -y inotify-tools;

# copy repo contents into container
COPY . /root/osg-exam

# install class (as described in Readme.md, for now.)
RUN mkdir -p $(kpsewhich -var-value=TEXMFHOME)/tex;
RUN ln -s /root/osg-exam/osgexam $(kpsewhich -var-value=TEXMFHOME)/tex/osgexam;
RUN texhash;

# install latexmkrc for building later on
RUN ln -s /root/osg-exam/osgexam/latexmkrc /root/.latexmkrc;
