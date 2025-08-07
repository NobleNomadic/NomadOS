import sys

# Constants for floppy disk structure
HEADS = 2
SECTORS_PER_TRACK = 18
# Calculation function
def calculateCHS(lbaSector):
  lbaSector = int(lbaSector) # Convert input to integer
  cylinder = lbaSector // (HEADS * SECTORS_PER_TRACK)

  temp = lbaSector % (HEADS * SECTORS_PER_TRACK)
  head = temp // SECTORS_PER_TRACK
  sector = (temp % SECTORS_PER_TRACK) + 1  # Sector numbers start at 1

  return f"CHS Address of sector {lbaSector}\nC: {cylinder}\nH: {head}\nS: {sector}"

# Entry point
if __name__ == "__main__":
  # Usage fail
  if len(sys.argv) < 2:
    print("Usage: python3 chscalc.py <Sector>")
    exit(1)

  # Extract arguments
  sector = sys.argv[1]

  # Find the CHS address of the sector
  CHSAddress = calculateCHS(sector)
  print(CHSAddress)
  exit(0)
