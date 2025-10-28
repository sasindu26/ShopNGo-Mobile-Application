import React, { useState } from 'react';
import { auth, db } from '../firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { useNavigate } from 'react-router-dom';

// Color Palette (for styling consistency)
const colors = {
  backgroundColor: '#FFF2F2',
  lightBlue: '#A9B5DF',
  mediumBlue: '#7886C7',
  darkBlue: '#2D336B',
};

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(''); // Clear previous errors
    try {
      // Step 1: Authenticate with Firebase Auth
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Step 2: Check user role in Firestore
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      if (!userDoc.exists()) {
        throw new Error('User data not found in Firestore');
      }

      const userData = userDoc.data();
      if (userData.role === 'admin') {
        // Step 3: Redirect to dashboard if admin
        navigate('/');
      } else {
        // If not admin, sign out and show error
        await auth.signOut();
        throw new Error('Access denied: Admin role required');
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div
      style={{
        padding: '20px',
        maxWidth: '400px',
        margin: '0 auto',
        backgroundColor: colors.backgroundColor,
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
      }}
    >
      <h2 style={{ color: colors.darkBlue }}>Admin Login</h2>
      <form onSubmit={handleLogin}>
        <div style={{ marginBottom: '16px' }}>
          <label style={{ color: colors.mediumBlue }}>Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{
              width: '100%',
              padding: '8px',
              marginTop: '4px',
              borderRadius: '8px',
              border: `1px solid ${colors.lightBlue}`,
            }}
          />
        </div>
        <div style={{ marginBottom: '16px' }}>
          <label style={{ color: colors.mediumBlue }}>Password</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{
              width: '100%',
              padding: '8px',
              marginTop: '4px',
              borderRadius: '8px',
              border: `1px solid ${colors.lightBlue}`,
            }}
          />
        </div>
        <button
          type="submit"
          style={{
            padding: '10px',
            width: '100%',
            backgroundColor: colors.darkBlue,
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            cursor: 'pointer',
          }}
        >
          Login
        </button>
      </form>
      {error && <p style={{ color: 'red', marginTop: '12px' }}>{error}</p>}
    </div>
  );
};

export default Login;