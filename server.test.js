const request = require('supertest');

describe('Server Tests', () => {
  let server;

  beforeAll(() => {
    server = require('./server');
  });

  afterAll((done) => {
    server.close(done);
  });

  test('GET /api/health should return healthy status', async () => {
    const response = await request(server).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
    expect(response.body).toHaveProperty('timestamp');
  });

  test('GET /api/message should return a message', async () => {
    const response = await request(server).get('/api/message');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('message');
    expect(response.body.message).toBe('Hello from CI/CD Pipeline!');
  });

  test('GET / should return HTML', async () => {
    const response = await request(server).get('/');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toMatch(/html/);
  });
});
