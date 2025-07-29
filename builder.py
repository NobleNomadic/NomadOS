import json

# Main builder
class builder:
  # Class init
  def __init__(self):
    self.configFilename = "buildconfig.txt"
    self.macroData = {}

  # Find and replace a trigger string with a macro
  def findAndReplace(self, triggerString, codeToInsert, filename):
    # Read the file into memory
    with open(filename, "r") as file:
    fileContents = file.read()

  # Replace each line if it contains the trigger string
  fileLines = fileContents.split("\n")
  updatedLines = [line.replace(triggerString, codeToInsert) for line in fileLines]

  # Write the updated lines back to the file
  with open(filename, "w") as file:
    file.write("\n".join(updatedLines))


  # Function to apply the config file
  def applyMacros(self):
    pass


  # Read the config file into the class properties
  def parseConfigFile(self):
    # Open the file
    with open(self.configFilename, "r") as configFile:
      self.macroData = json.load(configFile)
