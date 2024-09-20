# Use the official Miniconda3 image
FROM continuumio/miniconda3

# Set environment variables for conda
ENV CONDA_ENV_NAME=pyfrbus-env
ENV CONDA_ENV_PATH=/opt/conda/envs/$CONDA_ENV_NAME
ENV PATH=$CONDA_ENV_PATH/bin:$PATH

# Install system dependencies (build tools, BLAS/LAPACK, SuiteSparse, OpenBLAS, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    swig \
    libblas-dev \
    liblapack-dev \
    libsuitesparse-dev \
    libopenblas-dev \
    pkg-config \
    cmake \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory's contents into /app
COPY . /app

# Create the Conda environment with Python 3.10
RUN conda create -n $CONDA_ENV_NAME python=3.10 -y

# Activate the environment and install necessary packages from conda-forge
RUN /bin/bash -c "source activate $CONDA_ENV_NAME && conda install -c conda-forge scikit-umfpack pandas numpy=1.22.4 scipy=1.11.4 matplotlib=3.7.0 -y"

# Install the pyfrbus package with setup.py
RUN /bin/bash -c "source activate $CONDA_ENV_NAME && python setup.py install"

# Ensure the environment is activated by default in bash sessions
RUN echo "source activate $CONDA_ENV_NAME" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Make the container run bash by default to allow interaction
CMD ["bash"]

