#!/usr/bin/python3
import json
import subprocess
import re
import os

# Compile with NASM
def compile(srcFilename, buildFilename):
  command = f"nasm -f bin {srcFilename} -o {buildFilename}"
  subprocess.run(command, shell=True, check=True)

# Write binary to disk at specified sector
def writeToDisk(buildFilename, device, sector):
  command = f"dd if={buildFilename} of={device} bs=512 seek={sector - 1} conv=notrunc"
  subprocess.run(command, shell=True, check=True)

# Load JSON config file
def loadConfigFile():
  with open("config.json", "r") as configFile:
    configData = json.load(configFile)
    return configData

# Convert "0x0000:0x7C00" to (segment, offset)
def parseSegmentOffset(mem):
  segment, offset = mem.split(":")
  return int(segment, 16), int(offset, 16)

# Expand custom macros like ;LOAD_x, ;CALL_x, ;JUMP_x
def preprocess(srcFile, dstFile, config):
  with open(srcFile, "r") as f:
    lines = f.readlines()

  newLines = []
  for line in lines:
    match = re.match(r"\s*;(\w+)_([\w\d]+)", line)
    if match:
      directive = match.group(1)
      objName = match.group(2)

      if objName not in config["objects"]:
        raise Exception(f"Unknown object: {objName}")

      obj = config["objects"][objName]
      seg, off = parseSegmentOffset(obj["mem"])
      chs = obj["chs"]
      c, h, s = chs["c"], chs["h"], chs["s"]
      secCount = obj.get("sectors", 1)

      if directive == "LOAD":
        newLines.extend([
          f"  ; LOAD_{objName}\n",
          f"  mov ch, {c}\n",
          f"  mov cl, {s}\n",
          f"  mov dh, {h}\n",
          f"  mov dl, 0x00\n",
          f"  mov bx, 0x{off:04X}\n",
          f"  mov ax, 0x{seg:04X}\n",
          f"  mov es, ax\n",
          f"  mov ah, 0x02\n",
          f"  mov al, {secCount}\n",
          f"  int 0x13\n"
        ])
      elif directive == "CALL":
        newLines.append(f"  ; CALL_{objName}\n")
        newLines.append(f"  call 0x{off:04X}\n")
      elif directive == "JUMP":
        newLines.append(f"  ; JUMP_{objName}\n")
        newLines.append(f"  jmp 0x{off:04X}\n")
      else:
        raise Exception(f"Unknown directive: {directive}")
    else:
      newLines.append(line)

  with open(dstFile, "w") as f:
    f.writelines(newLines)

# Main build routine
if __name__ == "__main__":
  configData = loadConfigFile()

  for name in configData["objects"]:
    obj = configData["objects"][name]
    src = obj["src"]
    preprocessed = src.replace(".asm", ".pp.asm")
    binFile = obj["bin"]
    sector = obj["sector"]

    print(f"Building object: {name}")
    preprocess(src, preprocessed, configData)
    compile(preprocessed, binFile)
    writeToDisk(binFile, "build/os.img", sector)
