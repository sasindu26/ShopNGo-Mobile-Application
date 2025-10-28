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

const Items = () => {
  const [items, setItems] = useState([]);

  useEffect(() => {
    const fetchItems = async () => {
      const querySnapshot = await getDocs(collection(db, 'items'));
      const itemList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setItems(itemList);
    };
    fetchItems();
  }, []);

  const handleDelete = async (id) => {
    await deleteDoc(doc(db, 'items', id));
    setItems(items.filter(item => item.id !== id));
  };

  return (
    <div>
      <Typography variant="h4" sx={{ color: colors.darkBlue, marginBottom: '20px' }}>
        Manage Items
      </Typography>
      <StyledTable>
        <TableHead>
          <TableRow sx={{ backgroundColor: colors.lightBlue }}>
            <TableCell>Name</TableCell>
            <TableCell>Price</TableCell>
            <TableCell>Category</TableCell>
            <TableCell>Seller ID</TableCell>
            <TableCell>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {items.map(item => (
            <TableRow key={item.id}>
              <TableCell>{item.name}</TableCell>
              <TableCell>${item.price}</TableCell>
              <TableCell>{item.category}</TableCell>
              <TableCell>{item.sellerId}</TableCell>
              <TableCell>
                <Button
                  variant="contained"
                  color="error"
                  onClick={() => handleDelete(item.id)}
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

export default Items;