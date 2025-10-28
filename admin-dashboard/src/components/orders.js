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

const Orders = () => {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const fetchOrders = async () => {
      const querySnapshot = await getDocs(collection(db, 'orders'));
      const orderList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setOrders(orderList);
    };
    fetchOrders();
  }, []);

  const handleDelete = async (id) => {
    await deleteDoc(doc(db, 'orders', id));
    setOrders(orders.filter(order => order.id !== id));
  };

  return (
    <div>
      <Typography variant="h4" sx={{ color: colors.darkBlue, marginBottom: '20px' }}>
        Manage Orders
      </Typography>
      <StyledTable>
        <TableHead>
          <TableRow sx={{ backgroundColor: colors.lightBlue }}>
            <TableCell>Order ID</TableCell>
            <TableCell>User ID</TableCell>
            <TableCell>Item ID</TableCell>
            <TableCell>Total</TableCell>
            <TableCell>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {orders.map(order => (
            <TableRow key={order.id}>
              <TableCell>{order.id}</TableCell>
              <TableCell>{order.userId}</TableCell>
              <TableCell>{order.itemId}</TableCell>
              <TableCell>${order.total}</TableCell>
              <TableCell>
                <Button
                  variant="contained"
                  color="error"
                  onClick={() => handleDelete(order.id)}
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

export default Orders;