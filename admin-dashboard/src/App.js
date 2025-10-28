// src/App.js
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { auth } from './firebase'; // Adjust path to your firebase config
import Dashboard from './components/dashboard'; // Adjust path as needed
import Users from './components/users'; // Placeholder for Users component
import Items from './components/items'; // Placeholder for Items component
import Orders from './components/orders'; // Placeholder for Orders component
import Login from './components/login'; // Placeholder for Login component

// Theme configuration
const theme = createTheme({
  palette: {
    background: {
      default: '#FFF2F2', // backgroundColor
    },
    primary: {
      main: '#2D336B', // darkBlue
    },
    secondary: {
      main: '#7886C7', // mediumBlue
    },
  },
});

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Listen to Firebase auth state changes
  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((currentUser) => {
      setUser(currentUser);
      setLoading(false);
    });
    return () => unsubscribe(); // Cleanup subscription
  }, []);

  if (loading) {
    return <div>Loading...</div>; // Show loading state while auth initializes
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route
            path="/"
            element={user ? <Dashboard /> : <Navigate to="/login" />}
          >
            <Route path="users" element={user ? <Users /> : <Navigate to="/login" />} />
            <Route path="items" element={user ? <Items /> : <Navigate to="/login" />} />
            <Route path="orders" element={user ? <Orders /> : <Navigate to="/login" />} />
          </Route>
          <Route path="/login" element={!user ? <Login /> : <Navigate to="/" />} />
          <Route path="*" element={<Navigate to={user ? "/" : "/login"} />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;