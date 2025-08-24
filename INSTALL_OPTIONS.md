# Nova CLI One-Line Installation Options

## Option 1: GitHub Pages (Recommended)

Create a simple GitHub Pages site to host the install script:

1. Create a new **public** repository called `nova-install`
2. Add the `install-nova.sh` script to it
3. Enable GitHub Pages
4. Users can then run:
```bash
curl -sSL https://ceobitch.github.io/nova-install/install-nova.sh | bash
```

## Option 2: Gist (Quick Setup)

1. Create a public GitHub Gist with the `install-nova.sh` content
2. Users can run:
```bash
curl -sSL https://gist.githubusercontent.com/ceobitch/GIST_ID/raw/install-nova.sh | bash
```

## Option 3: Hosted Service

Upload the script to any web hosting service:
- Netlify (free)
- Vercel (free) 
- GitHub Pages (free)
- Your own domain

## Option 4: Make Repository Public

If you want to make the nova-cli repository public, the original approach would work:
```bash
curl -sSL https://raw.githubusercontent.com/ceobitch/nova-cli/main/install-nova.sh | bash
```

## Recommended Approach

**Use GitHub Gist for immediate solution:**

1. Go to https://gist.github.com/
2. Create a new public gist called `install-nova.sh`
3. Paste the content from `install-nova.sh`
4. Save it
5. Get the raw URL and update the README

This gives you the one-line install command you want!
