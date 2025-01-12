Crea il Dockerfile

podman build -t my-nextjs-app . --no-cache
podman run -p 3000:3000 my-nextjs-app

comandi podman:

# per cancellare l'immagine
podman rmi a4d398446988

# Builda l'immagine
podman build -t my-nextjs-app . --target builder

# Entra nel builder stage per verificare la struttura
podman run -it my-nextjs-app sh
