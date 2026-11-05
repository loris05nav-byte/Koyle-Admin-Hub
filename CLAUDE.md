# Instructions pour Claude

- Après chaque modification, commit et push **automatiquement sur `main`** (sans demander, sans PR) :
  le système de clé et l'executor chargent les scripts depuis `refs/heads/main`, donc une modification
  qui n'est pas sur `main` n'est pas active en jeu.
