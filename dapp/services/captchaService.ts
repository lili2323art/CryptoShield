import ImageBg from '@/assets/1bg@2x.jpg';
import ImagePuzzle from '@/assets/1puzzle@2x.png';

export const getCaptcha = async () => {
  console.log({
    bgUrl: ImageBg,
    puzzleUrl: ImagePuzzle
  });

  return {
    bgUrl: ImageBg.src,
    puzzleUrl: ImagePuzzle.src
  };
};

export const verifyCaptcha = async (data: { x: number }) => {
  if (data?.x && data.x > 87 && data.x < 93) {
    return Promise.resolve();
  }
  return Promise.reject();
};

export default {};
