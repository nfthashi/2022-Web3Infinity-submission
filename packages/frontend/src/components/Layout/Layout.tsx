import { Box, Container, Flex } from "@chakra-ui/react";
import React from "react";

import config from "../../../config.json";
import { Footer } from "../Footer";
import { Header } from "../Header";

export interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  return (
    <Box backgroundColor={config.styles.background.color.layout}>
      <Flex minHeight={"100vh"} direction={"column"}>
        <Header />
        <Container flex={1} maxWidth="xl" p="4">
          {children}
        </Container>
        <Footer />
      </Flex>
    </Box>
  );
};
