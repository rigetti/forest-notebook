# build from the forest Docker image
FROM rigetti/forest:2.16.0

# install requirements for latex generation
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install --no-install-recommends -yq \
    ghostscript imagemagick texlive-latex-base texlive-latex-extra && \
    rm -rf /var/lib/apt/lists/*

# install requirements for running pyquil example notebooks
RUN pip install -r /src/pyquil/examples/requirements.txt

# install forest-benchmarking for QCVV toolkit
RUN pip install forest-benchmarking==0.7.1

# install jupyter notebook and jupyter lab
RUN pip install --no-cache-dir notebook==6.0.1 jupyterlab==1.1.4

# create user with UID 1000 and associated home dir (required by binder)
ARG NB_USER=binder
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# copy over files from the repository into /home/forest-notebook
COPY . /src/forest-notebook

# transfer ownership of /home/binder and /src to binder user
USER root
RUN chown -R ${NB_UID} ${HOME}
RUN chown -R ${NB_UID} /src
USER ${NB_USER}

# signal that we need to publish port 8888 to run the notebook server
EXPOSE 8888

# run the notebook server
WORKDIR /src/pyquil
CMD ["jupyter", "lab", "--ip=0.0.0.0"]
