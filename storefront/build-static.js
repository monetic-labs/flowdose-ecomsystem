// Custom build script that uses stub data for Docker builds
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Check if running in Docker build environment
const isDocker = process.env.CI === 'true';

if (isDocker) {
  console.log('Running in Docker build environment, using stub data');
  
  // Create temporary paths to stub dynamic data fetching
  const srcDir = path.join(__dirname, 'src');
  const stubPaths = [
    'actions',
    'lib/data',
    'lib/hooks'
  ];
  
  // Create stub data files directly without trying to rename directories
  stubPaths.forEach(stubPath => {
    const fullPath = path.join(srcDir, stubPath);
    if (fs.existsSync(fullPath)) {
      try {
        // Instead of renaming, replace the content of index files
        const indexFilePath = path.join(fullPath, 'index.js');
        if (fs.existsSync(indexFilePath)) {
          // Save original content
          const originalContent = fs.readFileSync(indexFilePath, 'utf8');
          // Write to a backup file
          fs.writeFileSync(`${indexFilePath}.bak`, originalContent);
          
          // Create stub content
          fs.writeFileSync(
            indexFilePath, 
            `// Stub data for build\nmodule.exports = {\n  prefetchCategories: () => ({ collections: [], count: 0 }),\n  prefetchProducts: () => ({ products: [], count: 0 }),\n  prefetchRegions: () => ([])\n};`
          );
          
          console.log(`Stubbed ${indexFilePath}`);
        }
      } catch (err) {
        console.error(`Error creating stub for ${stubPath}:`, err);
      }
    }
  });
}

try {
  // Run the Next.js build command with the full path to the executable
  console.log('Starting Next.js build...');
  execSync('NODE_ENV=production ./node_modules/.bin/next build', { 
    stdio: 'inherit',
    env: {
      ...process.env,
      NODE_ENV: 'production',
      NEXT_PUBLIC_SKIP_PREFETCH: 'true',
      NEXT_SKIP_BUILD_FETCH: 'true'
    }
  });
} catch (error) {
  console.error('Build failed:', error);
  process.exit(1);
} finally {
  // Restore original files if we were in Docker
  if (isDocker) {
    stubPaths.forEach(stubPath => {
      const fullPath = path.join(srcDir, stubPath);
      const indexFilePath = path.join(fullPath, 'index.js');
      const backupPath = `${indexFilePath}.bak`;
      
      if (fs.existsSync(backupPath)) {
        try {
          // Restore from backup
          const originalContent = fs.readFileSync(backupPath, 'utf8');
          fs.writeFileSync(indexFilePath, originalContent);
          fs.unlinkSync(backupPath);
          
          console.log(`Restored ${indexFilePath}`);
        } catch (err) {
          console.error(`Error restoring ${stubPath}:`, err);
        }
      }
    });
  }
} 