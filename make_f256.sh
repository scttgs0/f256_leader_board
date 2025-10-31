
mkdir -p obj/

# -------------------------------------

64tass  --m65816 \
        --c256-pgz \
        --output-exec=BOOT \
        --long-address \
        -D PGZ=1 \
        -o obj/leaderboard.pgz \
        --list=obj/leaderboard.lst \
        --labels=obj/leaderboard.lbl \
        leaderboard.asm
