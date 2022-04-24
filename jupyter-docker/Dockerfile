ARG BASE_IMAGE=jupyterhub/jupyterhub:2.2.2
FROM ${BASE_IMAGE}
RUN pip install --no-cache --upgrade jupyter
RUN pip install --no-cache dockerspawner
RUN pip install --no-cache numpy scipy scikit-learn statsmodels matplotlib
ADD sources.list /etc/apt/
RUN apt-get update && apt-get install -y r-base
RUN /usr/bin/R -e 'install.packages(c("IRkernel"))' && /usr/bin/R -e 'IRkernel::installspec()'
EXPOSE 8000
