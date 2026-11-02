# ia-lab — Environnement Docker pour les TP de deep learning

Environnement JupyterLab conteneurisé avec PyTorch CPU, scikit-learn et les bibliothèques de visualisation.

## Démarrage rapide

```bash
# 1. Copier et configurer les variables d'environnement
cp .env.example .env
# Éditer .env : renseigner JUPYTER_TOKEN, LAB_UID, LAB_GID

# 2. Construire et démarrer
docker compose up -d --build

# 3. Afficher l'URL de JupyterLab
docker compose exec lab jupyter lab list
```

## Commandes courantes

```bash
# Voir les logs
docker compose logs -f lab

# Ouvrir un shell dans le conteneur
docker compose exec lab bash

# Arrêter l'environnement
docker compose down

# Reconstruire après modification des dépendances
docker compose up -d --build
```

## Organisation du projet

```
ia-lab/
├── compose.yaml          # Configuration Docker Compose
├── Dockerfile            # Image Python + PyTorch CPU
├── requirements.txt      # Dépendances principales
├── requirements-torch.txt # PyTorch (index CPU uniquement)
├── .env                  # Variables d'environnement (non versionné)
├── .env.example          # Modèle de .env
├── notebooks/            # Notebooks Jupyter
├── src/                  # Code source Python (dans PYTHONPATH)
├── data/                 # Données (non versionné sauf .gitkeep)
└── models/               # Modèles sauvegardés (non versionné sauf .gitkeep)
```

## Ajouter une dépendance

1. Ajouter le package dans `requirements.txt` (ou `requirements-torch.txt` pour les packages PyTorch).
2. Reconstruire l'image :
   ```bash
   docker compose up -d --build
   ```

**Important :** les packages PyTorch doivent être installés uniquement depuis l'index CPU (`https://download.pytorch.org/whl/cpu`). Ne jamais utiliser `--extra-index-url` pour éviter d'installer une version CUDA par accident.

# Extrat tips

## Docker jetable pour les executions douteuses
```bash
mkdir -p ~/sandbox-ia
docker run --rm -it \
  --network none \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --memory 8g \
  -v ~/sandbox-ia:/workspace \
  ia-lab:cpu bash
  ```
## Env CHECK 
  ```bash
  docker compose exec lab python -c "
from importlib.metadata import version
for p in ['numpy','pandas','matplotlib','seaborn','scikit-learn','jupyterlab','torch','torchvision']:
    print(f'{p:<14}{version(p)}')
import numpy, pandas, matplotlib, seaborn, sklearn, torch, torchvision
print('imports OK | CUDA :', torch.version.cuda)
"
  docker compose exec lab pip check
  ```
