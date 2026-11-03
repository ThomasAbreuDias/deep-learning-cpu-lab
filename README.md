# ia-lab — Environnement Docker pour pratiquer les réseau de neurones  ( Machine/Deep learning)

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

## Démarrage d'un session 

### 1. Récupérer le projet

```bash
git clone https://github.com/ThomasAbreuDias/deep-learning-cpu-lab.git
cd deep-learning-cpu-lab
```

Prérequis : Docker et Docker Compose, avec un utilisateur autorisé à lancer `docker`.

### 2. Configurer

```bash
cp .env.example .env
sed -i "s/^JUPYTER_TOKEN=.*/JUPYTER_TOKEN=$(openssl rand -hex 32)/" .env
sed -i "s/^LAB_UID=.*/LAB_UID=$(id -u)/; s/^LAB_GID=.*/LAB_GID=$(id -g)/" .env
```

| Variable | Rôle | Valeur |
| --- | --- | --- |
| `JUPYTER_TOKEN` | Accès à JupyterLab | Générée ci-dessus, obligatoire |
| `JUPYTER_PORT` | Port local | `8888`, à changer s'il est déjà pris |
| `LAB_UID`, `LAB_GID` | Propriétaire des fichiers | Ton utilisateur |
| `LAB_MEM_LIMIT` | RAM maximale | `24g` sur 32 Go, à baisser si le PC manque de mémoire |

Si des modification sont faite sur `LAB_UID` ou `LAB_GID`, reconstruire l'image. Pour les autres variables, `docker compose up -d` suffit.

### 3. Démarrer

```bash
docker compose up -d --build
docker compose ps
```

Attendre l'état `healthy`. Le premier build prend plusieurs minutes, les suivants sont bien plus rapides.

### 4. Ouvrir JupyterLab

```bash
source .env && echo "http://127.0.0.1:${JUPYTER_PORT}/lab?token=${JUPYTER_TOKEN}"
```

Ouvrir l'URL affichée dans le navigateur.

### 5. Vérifier

```bash
docker compose exec lab jupyter execute notebooks/00_verification.ipynb
docker compose exec lab pip check
```

### 6. Installer les datasets

Tout va dans `data/`, ce qui les conserve sur ton disque sans les envoyer sur Git. Dans le conteneur, ce dossier correspond à `/workspace/data`.

**Fichiers CSV ou fournis par le cours :** à copier dans un sous-dossier, par exemple `data/tp1/`, puis :

```python
import pandas as pd

df = pd.read_csv("/workspace/data/tp1/train.csv")
```

**Datasets torchvision (MNIST, CIFAR-10, etc.) :**

```python
from torchvision import datasets, transforms

train = datasets.MNIST(
    root="/workspace/data",
    train=True,
    download=True,
    transform=transforms.ToTensor(),
)
```

Il est téléchargé une seule fois, puis réutilisé.

**Datasets scikit-learn téléchargés :** préciser `data_home`, sinon le cache part dans le home du conteneur et sera perdu à sa recréation.

```python
from sklearn.datasets import fetch_openml

mnist = fetch_openml("mnist_784", as_frame=True, data_home="/workspace/data/sklearn")
```

`load_digits()` et `load_iris()` sont inclus dans scikit-learn : rien à télécharger.

### 7. Organiser ton travail

- **`notebooks/`** 
- **`src/`** : Code réutilisable, à importer avec `from mon_module import ...`.
- **`models/`** : Poids, par exemple `torch.save(model.state_dict(), "/workspace/models/mlp_tp1.pt")`.

### 8. Au quotidien

```bash
docker compose up -d                # démarrer
docker compose logs -f lab          # lire les logs
docker compose exec lab bash        # ouvrir un shell
docker compose down                 # arrêter
docker compose up -d --build        # après un changement de requirements
```

`docker compose down` ne supprime pas tes fichiers.

Éviter `git clean -fdx`, qui effacerait `.env`, `data/` et `models/`.

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
