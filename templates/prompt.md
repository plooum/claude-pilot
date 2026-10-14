# Prompt NN : <slug>

Tu travailles dans **`<chemin du checkout ou du worktree>`** sur la branche **`feature/<nom>`**, à partir d'un `main` à jour. Charge les skills : `pilot-subagent`, <les skills de livraison / de test du projet>. <Règles propres au projet qui s'appliquent, en une ligne.> Ouvre la PR, ne la fusionne jamais. Une question que tu ne peux pas trancher : arrête-toi et signale-la (Questions ouvertes), n'attends pas.

## Objectif

<Quoi et pourquoi, quelques lignes. Les décisions de l'utilisateur ci-dessous sont des **exigences fixes** ; ne les rouvre pas.>

- <décision 1 (utilisateur, date)>
- <décision 2>

## Conception (fixe)

<Où va le code, quelles fonctions et quelles lignes approximatives toucher, ce qui est partagé, les noms. Les sections de fichiers à lire (jamais « lis tout le fichier »). Les prémisses que tu as vérifiées dans le projet.>

## Vérifications (strict minimum)

<Une vérification par exigence, aucun cas en plus ; ou « pas de suite : une commande / une vérification à la main ». Quels tests écrire (fichier, noms des tests, ce que chacun vérifie) et lesquels lancer à la fin, une seule fois. « Voie rapide » pour un correctif d'une fonction.>

Captures d'écran : <aucune | les 1-2 qui doivent montrer X et Y>.

## Livraison

PR « <titre> » sur `feature/<nom>`. Ouvre-la, ne la fusionne jamais. Rapport au format de `pilot-subagent`. Les frictions comptent.
