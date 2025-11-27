/**
 * Global error handler middleware
 */

export const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);
  
  // Default error
  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  // Don't leak error details in production
  const errorResponse = {
    error: message,
    ...(process.env.NODE_ENV === 'development' && { 
      stack: err.stack,
      details: err.details 
    })
  };
  
  res.status(status).json(errorResponse);
};

