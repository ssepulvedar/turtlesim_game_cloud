FROM ubuntu:22.04

# Configuración de zona horaria y variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Instalar dependencias básicas y ROS2 Humble
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    build-essential \
    python3-colcon-common-extensions

# Agregar repositorio de ROS2 Humble
RUN curl -sSL http://repo.ros2.org/repos.key | apt-key add - && \
    echo "deb [arch=amd64] http://repo.ros2.org/ubuntu/main $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list && \
    apt-get update && \
    apt-get install -y ros-humble-desktop

# Instalar Foxglove Bridge
RUN apt-get install -y ros-humble-foxglove-bridge

# Configurar el workspace
RUN mkdir -p /workspace/ros2_ws/src
WORKDIR /workspace/ros2_ws
# Copia el código del proyecto al contenedor (opcional, si lo tienes en el repo)
COPY . /workspace/ros2_ws/src/your_project

# Compila el workspace
RUN . /opt/ros/humble/setup.sh && colcon build

# Exponer el puerto del Foxglove Bridge (por defecto es el 8765)
EXPOSE 8765

# Comando de entrada: inicia el Foxglove Bridge y luego un bash para trabajar
CMD ["/bin/bash", "-c", ". /opt/ros/humble/setup.sh && ros2 run foxglove_bridge foxglove_bridge"]
