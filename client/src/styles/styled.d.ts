import styled from 'styled-components';

declare module 'styled-components' {
  export interface DefaultTheme {
    typography: {
      h1: {
        fontSize: string;
        lineHeight: string;
      };
      h2: {
        fontSize: string;
        lineHeight: string;
      };
      h3: {
        fontSize: string;
        lineHeight: string;
      };
    };
    colors: {
      black: string;
      lightGrey: string;
      grey: string;
      darkGrey: string;
      white: string;
      purple: string;
    };
    border: {
      wavyRadius: string;
    };
    space: Array<number>;
    spacings: (spacing: number) => string;
    ui: {
      text: string;
      background: string;
      card: {
        border: string;
      };
      button: {
        color: string;
        background: string;
        border: string;
      };
      modal: {
        border: string;
        background: string;
      };
      alert: {
        text: string;
        background: string;
      };
    };
  }
}
