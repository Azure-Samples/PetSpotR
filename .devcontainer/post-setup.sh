# Install python dependencies
pip install -r /workspace/src/backend/requirements.txt

# dotnet restore
dotnet restore /workspace/src/frontend/PetSpotR/PetSpotR.csproj
