# TicTacToeKit

This package contains code that is shared between macos and IOS. For convenience this package also hosts the unit test.

Integrated in in example iOS and macOS app [TicTacToe](https://github.com/kata-me/TicTacToe)

## Setup pre-push hook

**Optional** To run a minimal set of tests before you push run following command in root folder.

⚠️ will overwrite whatever is in the pre-push, if you have a pre-push append rather then running this command.

```bash
mv .git/hooks/pre-push.sample .git/hooks/pre-push && echo '#!/bin/bash' > .git/hooks/pre-push && echo 'swift test' >> .git/hooks/pre-push
```
