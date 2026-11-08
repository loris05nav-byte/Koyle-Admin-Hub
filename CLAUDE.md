# Instructions pour Claude

- Après chaque modification, commit et push **automatiquement sur `main`** (sans demander, sans PR) :
  le système de clé et l'executor chargent les scripts depuis `refs/heads/main`, donc une modification
  qui n'est pas sur `main` n'est pas active en jeu.
- Toujours pousser **tous** les changements (y compris ceux qui remplacent des fichiers déjà présents sur `main`), sans demander.
  Ne jamais réécrire l'historique (`--force`) : si `main` a avancé, on intègre `origin/main` par un commit de merge.
