# Fork Setup

1. Install TortoiseGit to get the merge tool: `winget install tortoisegit`
2. Copy the merge tool from `c:\Program Files\TortoiseGit`
3. Merge tool arguments:
   ```
   -base:"$BASE" -mine:"$LOCAL" -theirs:"$REMOTE" -merged:"$MERGED"
   ```
