import React, { useEffect, useState } from 'react';
import { db } from '../firebase';
import { collection, getDocs, deleteDoc, doc } from 'firebase/firestore';
import { Table, TableBody, TableCell, TableHead, TableRow, Button, Typography } from '@mui/material';
import { styled } from '@mui/system';

const colors = {
  backgroundColor: '#FFF2F2',
  lightBlue: '#A9B5DF',
  mediumBlue: '#7886C7',
  darkBlue: '#2D336B',
};

const StyledTable = styled(Table)({
  backgroundColor: 'white',
  borderRadius: '12px',
  overflow: 'hidden',
});

const Users = () => {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    const fetchUsers = async () => {
      const querySnapshot = await getDocs(collection(db, 'users'));
      const userList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setUsers(userList);
    };
    fetchUsers();
  }, []);

  const handleDelete = async (id) => {
    await deleteDoc(doc(db, 'users', id));
    setUsers(users.filter(user => user.id !== id));
  };

  return (
    <div>
      <Typography variant="h4" sx={{ color: colors.darkBlue, marginBottom: '20px' }}>
        Manage Users
      </Typography>
      <StyledTable>
        <TableHead>
          <TableRow sx={{ backgroundColor: colors.lightBlue }}>
            <TableCell>Name</TableCell>
            <TableCell>Email</TableCell>
            <TableCell>Role</TableCell>
            <TableCell>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {users.map(user => (
            <TableRow key={user.id}>
              <TableCell>{user.name}</TableCell>
              <TableCell>{user.email}</TableCell>
              <TableCell>{user.role}</TableCell>
              <TableCell>
                <Button
                  variant="contained"
                  color="error"
                  onClick={() => handleDelete(user.id)}
                >
                  Delete
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </StyledTable>
    </div>
  );
};

export default Users;