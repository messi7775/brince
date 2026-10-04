module.exports = {
  rootDir: 'src',
  testEnvironment: 'node',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.ts$': ['ts-jest', { tsconfig: '../tsconfig.json' }],
  },
  modulePathIgnorePatterns: ['<rootDir>/generated/'],
};
