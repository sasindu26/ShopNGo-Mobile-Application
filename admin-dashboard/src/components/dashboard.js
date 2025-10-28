import React, { useState } from 'react';
import { Link, Outlet } from 'react-router-dom';
import { auth } from '../firebase';
import {
  AppBar,
  Toolbar,
  Typography,
  Drawer,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Box,
  Button,
  IconButton,
  CssBaseline,
  Avatar,
} from '@mui/material';
import { styled } from '@mui/system';
import MenuIcon from '@mui/icons-material/Menu';
import PeopleIcon from '@mui/icons-material/People';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import ListAltIcon from '@mui/icons-material/ListAlt';
import ExitToAppIcon from '@mui/icons-material/ExitToApp';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';

// Color Palette
const colors = {
  backgroundColor: '#FFF2F2',
  lightBlue: '#A9B5DF',
  mediumBlue: '#7886C7',
  darkBlue: '#2D336B',
};

const StyledDrawer = styled(Drawer)({
  width: 240,
  flexShrink: 0,
  '& .MuiDrawer-paper': {
    width: 240,
    background: `linear-gradient(180deg, ${colors.darkBlue}, ${colors.mediumBlue})`,
    color: 'white',
    borderRight: 'none',
  },
});

const CollapsedDrawer = styled(Drawer)({
  width: 60,
  flexShrink: 0,
  '& .MuiDrawer-paper': {
    width: 60,
    background: `linear-gradient(180deg, ${colors.darkBlue}, ${colors.mediumBlue})`,
    color: 'white',
    borderRight: 'none',
    overflowX: 'hidden',
  },
});

const Content = styled(Box)({
  flexGrow: 1,
  padding: '24px',
  backgroundColor: colors.backgroundColor,
  minHeight: '100vh',
});

const StyledListItem = styled(ListItem)({
  '&:hover': {
    backgroundColor: colors.lightBlue,
    color: colors.darkBlue,
    '& .MuiListItemIcon-root': {
      color: colors.darkBlue,
    },
  },
  '& .MuiListItemIcon-root': {
    color: 'white',
  },
});

const Dashboard = () => {
  const [drawerOpen, setDrawerOpen] = useState(true);
  const user = auth.currentUser;

  const handleLogout = () => {
    auth.signOut();
  };

  const toggleDrawer = () => {
    setDrawerOpen(!drawerOpen);
  };

  const menuItems = [
    { text: 'Users', icon: <PeopleIcon />, path: '/users' },
    { text: 'Items', icon: <ShoppingCartIcon />, path: '/items' },
    { text: 'Orders', icon: <ListAltIcon />, path: '/orders' },
  ];

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar
        position="fixed"
        sx={{
          zIndex: (theme) => theme.zIndex.drawer + 1,
          background: `linear-gradient(90deg, ${colors.darkBlue}, ${colors.mediumBlue})`,
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            edge="start"
            onClick={toggleDrawer}
            sx={{ mr: 2, ...(drawerOpen && { display: 'none' }) }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 'bold' }}>
            Admin Dashboard
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Avatar sx={{ bgcolor: colors.lightBlue, mr: 1 }}>
              {user?.email?.charAt(0).toUpperCase() || 'A'}
            </Avatar>
            <Typography variant="body1" sx={{ mr: 2, color: 'white' }}>
              {user?.email?.split('@')[0] || 'Admin'}
            </Typography>
            <Button
              color="inherit"
              onClick={handleLogout}
              startIcon={<ExitToAppIcon />}
              sx={{
                textTransform: 'none',
                '&:hover': { backgroundColor: colors.lightBlue, color: colors.darkBlue },
              }}
            >
              Logout
            </Button>
          </Box>
        </Toolbar>
      </AppBar>
      {drawerOpen ? (
        <StyledDrawer variant="permanent" anchor="left">
          <Toolbar sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <AdminPanelSettingsIcon sx={{ fontSize: 32, mr: 1 }} />
            <Typography variant="h6" noWrap>
              Admin Panel
            </Typography>
          </Toolbar>
          <List>
            {menuItems.map((item) => (
              <StyledListItem button component={Link} to={item.path} key={item.text}>
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.text} />
              </StyledListItem>
            ))}
          </List>
        </StyledDrawer>
      ) : (
        <CollapsedDrawer variant="permanent" anchor="left">
          <Toolbar />
          <List>
            {menuItems.map((item) => (
              <StyledListItem button component={Link} to={item.path} key={item.text}>
                <ListItemIcon>{item.icon}</ListItemIcon>
              </StyledListItem>
            ))}
          </List>
        </CollapsedDrawer>
      )}
      <Content component="main" sx={{ marginTop: '64px' }}>
        <Outlet />
      </Content>
    </Box>
  );
};

export default Dashboard;