if [ ! -d build ]; then
	mkdir build
fi

echo "🔧 Building 6502 project: eater"
rm -f build/eater.o
docker run --rm -v.:/workspace 6502-ca65 -D eater assembly/msbasic/msbasic.s -o build/eater.o
# check if assembly was successful
if [ $? -eq 0 ]; then
    echo "✅ Assembly successful! Output: eater.o"
else
    echo "❌ Assembly failed!"
    break
fi

echo "🔧 Linking 6502 project: eater"
rm -f build/eater.bin build/eater.lbl
docker run --rm --entrypoint=/opt/cc65/bin/ld65 -v .:/workspace 6502-ld65 -C assembly/eater.cfg build/eater.o -o build/eater.bin -Ln build/eater.lbl
# check if linking was successful
if [ $? -eq 0 ]; then
    echo "✅ Linking successful! Output: eater.bin"
else
    echo "❌ Linking failed!"
    break
fi

./scripts/program.sh "eater.bin"
