# React + Vite + SonarQube Project

This project demonstrates integration of React, Vite, Vitest testing, and SonarQube code quality analysis.

## Features

- ⚛️ React 18 with Vite for fast development
- 🧪 Vitest for unit testing
- 📊 Code coverage reporting
- 🔍 SonarQube integration for code quality analysis
- 🚀 GitHub Actions CI/CD pipeline

## Getting Started

### Prerequisites

- Node.js 18 or higher
- npm or yarn

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd my-react-sonarqube-project

# Install dependencies
npm install
```

### Development

```bash
# Start development server
npm run dev

# Run tests
npm run test

# Run tests with coverage
npm run test:coverage

# Build for production
npm run build
```

### Testing

This project uses Vitest for testing with the following setup:

- **Unit Tests**: Located in `src/components/__tests__/`
- **Coverage**: Generated in `coverage/` directory
- **Test Environment**: jsdom for React component testing

### SonarQube Integration

The project is configured to work with SonarQube for code quality analysis:

- **Configuration**: `sonar-project.properties`
- **Coverage Reports**: LCOV format from Vitest
- **CI Integration**: GitHub Actions workflow

### GitHub Actions

The CI pipeline includes:

1. **Dependencies Installation**: npm ci
2. **Testing**: Run tests with coverage
3. **Building**: Create production build
4. **SonarQube Analysis**: Upload results to SonarQube server

### Project Structure

```
src/
├── components/
│   ├── Calculator.jsx          # Main calculator component
│   └── __tests__/
│       └── Calculator.test.jsx # Component tests
├── test/
│   └── setup.js               # Test configuration
├── App.jsx                    # Main app component
└── main.jsx                   # Application entry point
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run test` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report
- `npm run lint` - Run ESLint

## SonarQube Setup

To set up SonarQube analysis:

1. Set up SonarQube server
2. Create a new project with key: `react-sonarqube-testing`
3. Generate authentication token
4. Add GitHub Secrets:
   - `SONAR_TOKEN`: Your SonarQube token
   - `SONAR_HOST_URL`: Your SonarQube server URL

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.