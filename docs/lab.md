# Welcome to the PetSpotR Build Lab

This guide will walk you through a set of exercises to run, deploy, and scale PetSpotR.

As part of this lab, you will:

1. Launch a GitHub Codespace and launch the application locally
2. Use GitHub Copilot to improve the application by adding in Dapr
3. Create a Bicep template and deploy the application to Azure
4. Use KEDA to scale the application to handle increased load

## Exercise 1: Run PetSpotR in a GitHub Codespace

Your first task is to launch a GitHub Codespace and launch PetSpotR within it.

### 1.1 Launch a GitHub Codespace

You'll begin by launching a GitHub Codespace. This will give you a pre-configured environment with all the tools you need to run PetSpotR.

1. Navigate to the [PetSpotR GitHub repository](https://github.com/Azure-Samples/PetSpotR/tree/build-2023-lab), and make sure you are on the `build-2023-lab` branch
2. Sign into GitHub with your GitHub account
3. Click the `<> Code` button and select the `Codespaces` tab
4. Click the `+` button to launch a new Codespace on the `build-2023-lab` branch

You should now drop directly into a Codespace with the PetSpotR repository cloned and ready to go.

### 1.2 Explore the Codespace

1. In the Codespace terminal, run `ls` to list the files in the repository:
    
    ```bash
    $ ls -1 -a
    ```
    > Note: The `-1` flag will list the files one per line, and the `-a` flag will list all files, including hidden files.

    You should see the following files:

    ```
    .
    ..
    .devcontainer
    docs
    .git
    .github
    .gitignore
    iac
    img
    LICENSE
    README.md
    src
    tests
    .vscode
    ```

    Important directories to note are:

    - `.devcontainer` contains the configuration for this Codespace environment.
    - `docs` contains the documentation for the application, including this lab guide.
    - `iac`  contains the Bicep infrastructure as code (IaC) for the application. We'll revisit this directory later in the lab.
    - `src`  contains the source code for the application's backend and frontend services.
    - `.vscode` contains the configuration for both the Codespace and Visual Studio Code.

2. Your Codespace also can run Docker containers inside of it. Run `docker ps` to list the running containers:
    
    ```bash
    $ docker ps
    ```

    You should see the following containers:

    ```
    CONTAINER ID   IMAGE                COMMAND                 ...
    57e30aa3124c   openzipkin/zipkin    "start-zipkin"          ...
    570e831d9299   daprio/dapr:1.10.5   "./placement"           ...
    ff778032cc52   redis:6              "docker-entrypoint.s…"  ...
    ```

    These are the default Dapr containers for Zipkin, Dapr placement service, running in the Codespace. They will be used when you run PetSpotR locally.
3. Open `.vscode/launch.json` to see the launch configurations for the Codespace. You'll use these to run PetSpotR locally:

    ```bash
    $ code .vscode/launch.json
    ```

    You should see launch configurations for:

    - `frontend with Dapr` - Launches the frontend service with Dapr
    - `backend with Dapr` - Launches the backend service with Dapr

    You'll also see a compound launch configuration called `✅ Debug with Dapr` that will launch both the frontend and backend services with Dapr.

### 1.3 Run PetSpotR locally

Now that you are familiar with the Codespace, you can run PetSpotR locally.

1. Select the `Run and Debug` tab in the left-hand pane of the Codespace.
2. Make sure the launch configuration is set to `✅ Debug with Dapr`
3. Click the `Start Debugging` button (▶️) to launch PetSpotR locally

You'll now see the PetSpotR application launch in a new browser tab. You can use this application to explore the functionality of PetSpotR.

### 1.4 Explore PetSpotR

You can now explore the PetSpotR application which is running in your Codespace.

> **Note**: Codespaces automatically forwards local ports and makes them available in the browser. The URL which was automatically opened uses `...app.github.dev` to connect you to your Codespace. You can also use the `PORTS` tab in the Codespace to find the port that was forwarded to the application.

1. Visit the `Lost` and `Found` pages to see the application's interface. Dapr has not been added to the application yet, so you'll see errors in the browser console if you try to fill out the form.
2. Return to your Codespace and take a look at your frontend logs. You'll see print statements for the `Lost` and `Found` pages, where calls to Dapr need to be added.
3. Stop the debuggers by clicking the `Stop Debugging` button (⏹️) in the top debug bar. You'll need to stop both the frontend and backend debuggers.

## Exercise 2: Use GitHub Copilot to add Dapr to the frontend

Your next task is to use GitHub Copilot to add Dapr to the PetSpotR application. GitHub Copilot is uses AI models to help you write code. You can use it to add Dapr to the PetSpotR application.

### 2.1 Add Dapr to the frontend

1. Open `src\frontend\PetSpotR\Data\PetModel.cs` to open the Pet model:
    
    ```bash
    $ code ./src/frontend/PetSpotR/Data/PetModel.cs
    ```
2. Add a new comment underneath the `public PetModel()` constructor, which describes what you want to do, in natural language:
    
    ```csharp
    // Save state to "pets" Dapr state store, using the supplied Dapr client
    ```
3. You'll now see GitHub Copilot suggest a new method to add to the Pet model. Hit `Tab` to accept the suggestion and add the method to the Pet model.

    > Note: If you don't see the suggestion, type `Ctrl + Enter` to force GitHub Copilot to suggest a method.

    ```csharp
    // Save state to "pets" Dapr state store, using the supplied Dapr client
    public async Task SavePetStateAsync(DaprClient daprClient)
    {
        await daprClient.SaveStateAsync("pets", ID, this);
    }
    ```
4. You'll now see a red squiggly line under the `SavePetStateAsync` method. This is because the Dapr.Client NuGet package needs to be added to the project. Click on the `DaprClientBuilder` method, click on the lightbulb, and select the `using Dapr.Client;` suggestion.
5. You'll notice that we're not using a try/catch block for this remote Dapr call. To add one, simply add a new line and type `try` and hit `Tab` to accept the suggestion. You'll now see a new try/catch block added to the method:

    ```csharp
    // Save state to "pets" Dapr state store, using the supplied Dapr client
    public async Task SavePetStateAsync(DaprClient daprClient)
    {
        try
        {
            await daprClient.SaveStateAsync("pets", ID, this);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error saving pet state: {ex.Message}");
        } 
    }
    ```

6. Now, try adding a new method to pubish a lost pet event to Dapr pub sub. Use comments and GitHub Copilot to suggest and add the method.

### 2.2 Create a Dapr component for Redis

Dapr components are used to configure Dapr to work with external services. You'll now create a Dapr component for Redis, which is running as a Docker container in your Codespace.

1. Open `iac\dapr\pets.yaml`, a file that is currently empty. This is where you'll add the Dapr component for Redis.
2. You'll start to see suggestions for the Dapr component from Copilot. Hit `Tab` and `Enter` as needed to accept the suggestions and add the component to the file. You should end up with the following component:

    ```yaml
    apiVersion: dapr.io/v1alpha1
    kind: Component
    metadata:
        name: pets
        namespace: default
    spec:
        type: state.redis
        version: v1
        metadata:
        - name: redisHost
          value: localhost:6379
        - name: redisPassword
          value: ""
    ```
3. By default, each service using Dapr gets its own unique state prefix. PetSpotR wil later share state between frontend and backend, so you'll need to add the following metadata to the bottom of your component:

    ```yaml
    - name: keyPrefix
      value: name
    ```
4. Rerun the `✅ Debug with Dapr` launch configuration to run PetSpotR locally. Submit a lost pet report, now leveraging Dapr and your Redis state store component. You can use the pet images stored in your lab VM under `Downloads\LostImages` to test the application.
5. Open the `Redis Explorer` tab on the left-hand pane of the Codespace. Click `Add` (_you may need to click twice_), and then `OK` to accept the defaults. Inside of `db0`, you'll see the `pets` state store and the `lostpets` and `foundpets` pub sub topics. Click on the entries to see the data you just saved to Dapr.

## Exercise 3: Use Bicep to model your infrastructure as code

We're now ready to deploy PetSpotR to Azure. You'll use Bicep to model your infrastructure as code. Bicep is a domain-specific language (DSL) for describing and deploying Azure resources declaratively. You'll use Bicep to deploy PetSpotR to Azure.

### 3.1 Create a Bicep template for your images storage account

1. Open `iac/infra.bicep` to open the Bicep template for your infrastructure:

    ```bash
    $ code ./iac/infra.bicep
    ```

    Notice that the template already has some resources defined, but it's missing an Azure storage account.

2. Create a new file, `storage.bicep`, which will contain the definition of your storage account:

    ```bash
    $ code ./iac/infra/storage.bicep
    ```

3. Using Copilot, add two parameters, one named `location` and one named `storageAccountName`. You can use comments as a starting point:

    ```bicep
    // Parameter for the location of the storage account

    // Parameter for the name of the storage account
    ```

4. Add a new resource, `storageAccount`, which will be an Azure storage account. Use Copilot with comments for suggestions to generate the resource:

    ```bicep
    // Storage account for storing images
    ```

5. To make the storage account available to other resources, you'll need to pass back the storage account's ID. Use another comment to have Copilot generate the output:

    ```bicep
    // Output for the storage account ID
    ```

    You should now have a `storage.bicep` file that looks like this:

    ```bicep
    // Parameter for the location of the storage account
    param location string = resourceGroup().location
    
    // Parameter for the name of the storage account
    param storageAccountName string
    
    // Storage account for storing images
    resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
      name: storageAccountName
      location: location
      kind: 'StorageV2'
      sku: {
        name: 'Standard_LRS'
      }
    }
    
    // Output for the storage account ID
    output storageAccountId string = storageAccount.id
    ```

6. Go back to `infra.bicep` and add a new module, `storage`, which will use the `storage.bicep` template you just created. Begin by typing `module` and using Bicep's intellisense (or Copilot) to add the module.

    > **Note:** Storage account names need to be globally unique. To ensure that your storage account name is unique, you can use the `uniqueString` function to generate a unique name based on the resource group ID

    ```bicep
    module storage 'infra/storage.bicep' = {
      name: 'storage'
      params: {
        location: location
        storageAccountName: uniqueString(resourceGroup().id)
      }
    }
    ```

### 3.2 Deploy your infrastructure to Azure

You're now ready to deploy your infrastructure to Azure. You'll use the Azure CLI to deploy your infrastructure:

1. Run `az login` to log in to Azure. You'll be prompted to open a browser window to authenticate. Use the credentials provided under the `Resources` tab:
  - @lab.CloudPortalCredential(User1).Username
  - @lab.CloudPortalCredential(User1).Password