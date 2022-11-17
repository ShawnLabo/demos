import {
  AppBar,
  Box,
  Container,
  MenuItem,
  Select,
  SelectChangeEvent,
  Toolbar,
  Typography,
} from "@mui/material";
import PetsIcon from "@mui/icons-material/Pets";
import Head from "next/head";
import React, { useCallback, useEffect, useState } from "react";

import { db } from "../src/firebase";
import {
  collection,
  doc,
  getDocs,
  onSnapshot,
  query,
  Unsubscribe,
} from "firebase/firestore";

type Dog = {
  name: string;
  unsubscribe: Unsubscribe;
};

export default function Home() {
  const [dogNames, setDogNames] = useState<string[]>([]);
  const [dog, setDog] = useState<Dog | null>(null);
  const [status, setStatus] = useState<string>("???");

  useEffect(() => {
    (async () => {
      const q = query(collection(db, "dogs"));
      const snapshot = await getDocs(q);
      setDogNames(snapshot.docs.map((doc) => doc.id));
    })();
  }, [setDogNames]);

  const onChangeDogName = useCallback(
    (e: SelectChangeEvent<string>) => {
      const name = e.target.value;

      setDog((currentValue) => {
        currentValue?.unsubscribe();

        const unsubscribe = onSnapshot(doc(db, "dogs", name), (doc) => {
          if (!doc) {
            return;
          }
          setStatus(doc.data()?.status || "???");
        });

        return { name, unsubscribe };
      });
    },
    [setDog, setStatus]
  );

  return (
    <Box sx={{ flexGrow: 1 }}>
      <Head>
        <title>Dog Status</title>
        <meta name="description" content="Dog status" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <AppBar position="static">
        <Container>
          <Toolbar disableGutters>
            <PetsIcon sx={{ mr: 1 }} />
            <Typography variant="h6" noWrap sx={{ flexGrow: 1 }}>
              Dog Status
            </Typography>
          </Toolbar>
        </Container>
      </AppBar>

      <Box component="main">
        <Toolbar />
        <Container>
          <Select
            value={dog?.name || ""}
            onChange={onChangeDogName}
            sx={{ minWidth: 300 }}
            displayEmpty
          >
            <MenuItem disabled value=""><em>Choose your dog</em></MenuItem>
            {dogNames.map((name, i) => (
              <MenuItem key={i} value={name}>
                {name}
              </MenuItem>
            ))}
          </Select>
        </Container>
        <Container>
          <Typography variant="h1" component="span">
            {dog ? `${dog.name} is ${status}` : ""}
          </Typography>
        </Container>
      </Box>
    </Box>
  );
}
