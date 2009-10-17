# Brains CLI

   brain new <name>
   brain push <name>
   brain push
   brain sync

## Steps

**New** action:

1. If the folder `~/.config` exists (Fish), create `~/.config/brains` else create `~/.brains`.
2. Fetch an API key from the server. This creates a new "brain" on the server.
3. Write API key to user file.
4. Create a new file <name>.rb and fill it with a template.
5. Add the full path to that file to the user file.

**Push** action:

1. Take all brains specified in user file, and push up to server with API key

**Sync** action:

1. Check brains mtimes
2. Wait 1 second
3. If any brains have been updated, push it to server
4. Loop
